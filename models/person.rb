module Comotion
  module Data
    module Person

      class Model < Struct.new(:id,
                               :type,
                               :displayName,
                               :directReportCount,
                               :followerCount,
                               :followingCount,
                               :status,
                               :thumbnailId,
                               :thumbnailUrl,
                               :location,
                               :tags,
                               :initialLogin,
                               :published,
                               :updated,
                               :emails,
                               :role
                              )
      end # class Model

      class Mapping
        def self.map
          {
            mappings: {
              person: {
                properties: {
                  type:              { type: 'string', store: true },
                  id:                { type: 'string', store: true },
                  displayName:       { type: 'string', store: true },
                  directReportCount: { type: 'integer', store: false },
                  followerCount:     { type: 'integer', store: true },
                  followingCount:    { type: 'integer', store: true },
                  status:            { type: 'string', store: true },
                  thumbnailId:       { type: 'string', store: false },
                  thumbnailUrl:      { type: 'string', store: false },
                  location:          { type: 'string', store: true },
                  tags:              { type: 'string', store: true },
                  initialLogin:      { type: 'date', store: true, format: 'yyyy-MM-dd HH:mm:ss Z' },
                  published:         { type: 'date', store: true, format: 'yyyy-MM-dd HH:mm:ss Z' },
                  updated:           { type: 'date', store: true, format: 'yyyy-MM-dd HH:mm:ss Z' },
                  emails: {
                    properties: {
                      value:      { type: 'string', store: true },
                      type:       { type: 'string', store: false },
                      jive_label: { type: 'string', store: false },
                      primary:    { type: 'boolean', store: true }
                    }
                  },
                  role:      { type: 'string', store: true },
                }
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
            type:              'person',
            id:                SecureRandom.uuid,
            displayName:       Faker::Name.name,
            directReportCount: 0,
            followerCount:     SecureRandom.random_number(999),
            followingCount:    SecureRandom.random_number(999),
            status:            Faker::Lorem.sentence(8,true),
            thumbnailId:       SecureRandom.uuid,
            thumbnailUrl:      Faker::Avatar.image,
            location:          "#{Faker::Address.latitude}, #{Faker::Address.longitude}",
            tags:              @@skills.sample(interests_count),
            initialLogin:      Faker::Time.backward(28),
            published:         Faker::Time.backward(28),
            updated:           Faker::Time.backward(7),
            emails: [
              {
                value:      Faker::Internet.email,
                type:       'comotion',
                jive_label: 'Email',
                primary:    true
              }
            ],
            role:              @@roles.sample,
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
              name:   doc['_source']['displayName'],
              email:  doc['_source']['emails'][0]['value'],
              avatar: doc['_source']['thumbnailUrl']
            }
          end

          data
        end # def from_elasticsearch
      end # class Formatter

    end # module Person
  end # module Data
end # module Comotion
