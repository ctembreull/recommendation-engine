module Comotion
  module Data
    class Elasticsearch
      attr_accessor :log

      def initialize(type = nil)
        @log   = false
        @index = 'comotion'
        @type  = type
        @debug = false
      end

      def client
        @@api_client ||= ::Elasticsearch::Client.new log: @log
      end

      def exists(id)
        client.send(:exists, {index: @index, type: @type, id: id})
      end

      def search(q = {query: {match_all: {}}})
        client.send(:search, {index: @index, type: @type, body: q})
      end
      alias_method :query, :search

      def create(id, doc)
        client.send(:index, {index: @index, type: @type, id: id, body: doc})
      end
      alias_method :index, :create

      def read(id)
        client.send(:get, {index: @index, type: @type, id: id})
      end
      alias_method :document, :read
      alias_method :get, :read

      def update(id, patch)
        client.send(:update, {index: @index, type: @type, id: id, body: {doc: patch} })
      end
      alias_method :patch, :update

      def delete(id)
        client.send(:delete, {index: @index, type: @type, id: id})
      end
      alias_method :destroy, :delete

      def create_or_update(doc)
        if exists(doc[:id])
          update(doc[:id], doc)
        else
          create(doc[:id], doc)
        end
      end
    end
  end
end
