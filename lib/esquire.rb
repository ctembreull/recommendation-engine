module Comotion
  module Data
    class Elasticsearch
      @@es_connection = nil

      def initialize(log = false)
        @@es_connection ||= ::Elasticsearch::Client.new log: log
      end

      def client
        @@es_connection
      end
    end
  end
end

module Esquire
  class Core
    attr_accessor :script_file, :terms, :src_weight, :tgt_weight, :max_boost, :boost_mode
    attr_accessor :index, :type


    def initialize
      @query = { match_all: {} }

      @index       = 'comotion'
      @type        = 'person'

      @script_type = :cvg_score
      @terms       = []
      @src_weight  = 1
      @tgt_weight  = 0
      @max_boost   = 0.99
      @boost_mode  = 'replace'
    end

    def client
      @@client ||= Elasticsearch::Client.new log: false
    end

    def cvg_score
      {
        function_score: {
          query:        @query,
          script_score: {
            file:   @script_type.to_s,
            params: {
              terms:      @terms,
              src_weight: @src_weight,
              tgt_weight: @tgt_weight
            }
          },
          max_boost:  @max_boost,
          boost_mode: @boost_mode
        }
      }
    end

    def run
      client.search index: @index, type: @type, body: build
    end
  end

  class UserMatch < Core
    def initialize(user_id, terms=[])
      super()
      @query = { match: { id: user_id } }
      @terms = terms
    end

    def build
      { query: cvg_score }
    end
  end

  class NetworkMatch < Core
    attr_accessor :network, :type

    def initialize(network = [], terms = [], type = 'person')
      super()
      @type    = type
      @network = network
      @terms   = terms
    end

    def filter
      {
        ids: {
          type:   @type,
          values: @network
        }
      }
    end

    def build
      {
        query: {
          filtered: {
            filter: filter,
            query:  cvg_score
          }
        }
      }
    end
  end

  class RecommendedUsers < Core
    def initialize(terms = [])
      super()
      @terms = terms
      @query = {
        terms:  {
          tags: @terms.map { |t| t.downcase }
        }
      }
    end

    def build
      @terms = @terms.map { |t| t.downcase }
      {
        query: {
          filtered: {
            query: cvg_score
          }
        }
      }
    end
  end
end
