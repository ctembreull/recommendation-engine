module Comotion
  module Data
    module Person

      class Model < Struct.new(:id, :username, :fullname, :email, :tags, :role, :type, :avatar, :seeking, :uwnetid, :url)
        # :followers, :following, :friends, :wishlist, :wish_met)
      end # class Model

      class Mapping
        def self.map
          {
            person: {
              properties: {
                id:        { type: 'string', store: true },
                fullname:  { type: 'string', store: true },
                username:  { type: 'string', store: true },
                email:     { type: 'string', store: true },
                uwnetid:   { type: 'string', store: true },
                tags:      { type: 'string', store: true },
                type:      { type: 'string', store: true },
                avatar:    { type: 'string', store: true },
                url:       { type: 'string', store: true },
                role:      { type: 'string', store: true },
                seeking:   { type: 'string', store: true },
                followers: { type: 'string', store: true },
                following: { type: 'string', store: true },
                friends:   { type: 'string', store: true },
                wishlist:  { type: 'string', store: true },
                wish_met:  { type: 'string', store: true }
              }
            }
          }
        end
      end # class Mapping

      class Stub
        @@roles  = %w(partner catalyst innovator staff)
        @@skills = ['Management', 'Business', 'Sales ', 'Marketing', 'Communication',
                    'Microsoft Office', 'Customer Service', 'Training', 'Microsoft Excel',
                    'Project Management', 'Designs', 'Analysis', 'Research', 'Websites',
                    'Budgets', 'Organization', 'Leadership', 'Time Management',
                    'Project Planning', 'Computer Program', 'Strategic Planning',
                    'Business Services', 'Applications', 'Reports', 'Microsoft Word',
                    'Program Management', 'Powerpoint', 'Negotation', 'Software',
                    'Networking', 'Offices', 'English', 'Data', 'Education', 'Events',
                    'International', 'Testing', 'Writing', 'Vendors', 'Advertising',
                    'Databases', 'Technology', 'Finance', 'Retail', 'Accounting',
                    'Social Media', 'Teaching', 'Engineering', 'Performance Tuning',
                    'Problem Solving', 'Marketing Strategy', 'Materials', 'Recruiting',
                    'Order Fulfillment', 'Corporate Law', 'Photoshop',
                    'New business development', 'Human resources', 'Public speaking',
                    'Manufacturing', 'Internal Audit', 'strategy', 'Employees', 'Cost',
                    'Business Development', 'Windows', 'Public Relations',
                    'Product Development', 'Auditing', 'Business Strategy',
                    'Presentations', 'Construction', 'Real Estate', 'Editing',
                    'Sales Management', 'Team Building', 'Healthcare', 'Revenue',
                    'Compliance', 'Legal', 'Innovation', 'Policy', 'Mentoring',
                    'Commercial Real Estate', 'Consulting', 'Information Technology',
                    'Process Improvement', 'Change management', 'Heavy Equipment',
                    'Teamwork', 'Promotions', 'Facilities Management']

        def self.seed
          require 'securerandom'
          require 'faker'

          interests_count = SecureRandom.random_number(12)
          interests_count = 1 if interests_count == 0
          {
            type:           'person',
            id:             SecureRandom.uuid,
            fullname:       Faker::Name.name,
            username:       Faker::Internet.user_name,
            email:          Faker::Internet.email,
            tags:           @@skills.sample(interests_count),
            role:           [@@roles.sample]
          }
        end # def seed
      end # class Stub


      class Formatter
        def self.from_elasticsearch(result)
          data = []
          return data if result['hits'].empty? || result['hits'].nil?

          result['hits']['hits'].each do |doc|
            data << {
              id:     doc['_id'],
              score:  doc['_score'],
              name:   doc['_source']['fullname'],
              email:  doc['_source']['email'],
              avatar: doc['_source']['avatar'],
              role:   doc['_source']['role']
            }
          end

          data
        end # def from_elasticsearch
      end # class Formatter

    end # module Person
  end # module Data
end # module Comotion
