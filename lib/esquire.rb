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

  module Config
    @@index  = 'comotion'
    @@client = nil

    def client
      @@client ||= Elasticsearch::Client.new log: false
    end

  end

  class UserRecommendation
    include Esquire::Config

    @type = 'person'

    attr_accessor :roles, :interests, :exclude

    def initialize(results = 10)
      @script     = 'cvg_score'
      @max_boost  = 0.99
      @src_weight = 1
      @tgt_weight = 0
      @roles      = []
      @interests  = []
      @exclude    = []
      @max_results = results
    end

    def debug
      @@index
    end

    def build
      {
        size: @max_results,
        query: {
          filtered: {
            filter: filter_atom,
            query:  query_atom
          }
        }
      }
    end

    def run
      client.search index: @@index, type: @type, body: build
    end

    def filter_atom
      return {} if @roles.empty?
      { terms: { role: @roles } }
    end

    def query_atom
      return {} if @interests.empty?
      {
        function_score: {
          query: {
            terms: { tags: @interests }
          },
          script_score: {
            file: @script,
            params: {
              terms:      @interests,
              src_weight: @src_weight,
              tgt_weight: @tgt_weight
            }
          },
          max_boost: @max_boost,
          boost_mode: 'replace'
        }
      }
    end
  end




end
