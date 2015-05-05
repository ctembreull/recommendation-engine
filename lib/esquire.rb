module Esquire
  class Core
    attr_accessor :script_file, :terms, :src_weight, :tgt_weight, :max_boost, :boost_mode
    attr_accessor :index, :type, :size, :order


    def initialize
      @query = { match_all: {} }

      @index       = 'comotion'
      @type        = 'person'
      @order       = 'desc'
      @size        = 100

      @script_type = :cvg_score
      @terms       = []
      @src_weight  = 1
      @tgt_weight  = 0
      @max_boost   = 0.99
      @boost_mode  = 'replace'
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

    def score_sort
      { _score: { order: @order } }
    end

  end

  class UserMatch < Core
    def initialize(user_id, terms=[])
      super()
      @query = { match: { id: user_id } }
      @terms = terms
    end

    def build
      {
        query: cvg_score,
        sort: score_sort
      }
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
      query = {
        query: {
          filtered: {
            filter: filter,
            query:  cvg_score
          }
        },
        sort: score_sort
      }

      query[:size] = @size unless @size.nil?

      query
    end
  end

  class RecommendedUsers < Core
    def initialize(terms = [])
      super()
      @terms = terms
      @query = {
        terms:  {
          tags: @terms.map { |t| t.downcase unless t.nil? }
        }
      }
    end

    def build
      @terms = @terms.map { |t| t.downcase unless t.nil? }
      query  = {
        query: {
          filtered: {
            query: cvg_score
          }
        },
        sort: score_sort
      }

      query[:size] = @size unless @size.nil?

      query
    end
  end

  class CustomSearch < Core
    attr_accessor :best_fields, :pre_tags, :post_tags
    def initialize(query = '')
      super()
      @query       = query
      @best_fields = []

      @pre_tags  = '<span class="highlight">'
      @post_tags = '</span>'
    end

    def build
      q = {
        query: {
          filtered: {
            filter: {},
            query: {
              query_string: {
                query:  @query + '*',
                fields: @best_fields,
              }
            }
          }
        }
      }
    end

    def highlight
      atom = {
        pre_tags:  @pre_tags,
        post_tags: @post_tags,
        fields:    {}
      }
      @best_fields.each {|t| atom[:fields][t.to_sym] = {}}

      atom
    end



  end

  class GeoSearch < CustomSearch
    attr_accessor :best_fields, :distance, :unit

    def initialize(query = '')
      super(query)
      @lat      = 0
      @lon      = 0
      @distance = 5.to_s
      @unit     = 'mi'
      @best_fields = []
    end

    def center(lat,lon)
      @lat = lat
      @lon = lon
      geoshape
    end

    def radius(distance, unit = 'mi')
      @distance = distance.to_s
      @unit     = unit
      geoshape
    end

    def geoshape
      {
        lat: @lat,
        lon: @lon,
        radius: @distance + @unit
      }
    end

    def build
      query = super()
      query[:query][:filtered][:filter] = {
        geo_distance: {
          distance: @distance + @unit,
          'pin.location' => {
            lat: @lat,
            lon: @lon
          }
        }
      }
      query
    end
  end

  class DateSearch < CustomSearch
    def initialize
      super()
    end

    def slice(start_time, end_time)
    end

    def build
      query = super()
      query[:query][:filtered][:filter] = {
        range: {
          start_date: {
            gte: '',
            lte: '',
          }
        }
      }
      query
    end
  end

  class EventSearch
    def initialize(max = 10)
      @size = max
    end

    def set_geometry(lat = 0, lon = 0, radius = 5, units = 'mi')
      @lat    = lat
      @lon    = lon
      @radius = radius.to_s + units
      @geometry_units = units
    end

    def set_future(range = 7, units = 'd')
      @future = range.to_s + units
    end

    def geo_distance_filter
      {
        geo_distance: {
          distance: @radius,
          'pin.coords' => {
            lat: @lat,
            lon: @lon
          }
        }
      }
    end

    def date_range_filter
      {
        range: {
          start_time: {
            gte: 'now',
            lte: 'now+' + @future
          }
        }
      }
    end

    def geo_distance_sort
      {
        _geo_distance: {
          'pin.coords' => {
            lat: @lat,
            lon: @lon
          },
          order: 'asc',
          unit:  @geometry_units,
          distance_type: 'plane'
        }
      }
    end

    def start_time_sort
      {
        start_time: {
          order: 'asc'
        }
      }
    end

    def build
      {
        size: @size,
        query: {
          filtered: {
            query: {match_all: {}},
            filter: {
              and: [geo_distance_filter, date_range_filter]
            }
          }
        },
        sort: [geo_distance_sort, start_time_sort]
      }
    end



  end



end
