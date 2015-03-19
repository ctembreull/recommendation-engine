require 'elasticsearch'
require 'securerandom'
require 'faker'

HOST  = 'localhost'
PORT  = 9200
INDEX = 'demo'

es = Elasticsearch::Client.new log:false
def user_mapping
  {
    mappings: {
      user: {
        properties: {
          name:      { type: 'string', store: true },
          email:     { type: 'string', store: true },
          role:      { type: 'string', store: true },
          interests: { type: 'string', store: true, index: 'analyzed' },
          location:  { type: 'geo_point', store: true }
        }
      }
    }
  }
end

es.indices.delete(index: INDEX) if es.indices.exists(index: INDEX)
es.indices.create index: INDEX, type: 'user', body: user_mapping

types  = %w(partner catalyst innovator staff)
skills = ['Management', 'Business', 'Sales ', 'Marketing', 'Communication',
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

1000.times do
  icount = SecureRandom.random_number(12)
  icount = 1 if icount == 0
  user = {
    name:      Faker::Name.name,
    email:     Faker::Internet.email,
    role:      types.sample,
    interests: skills.sample(icount),
    location: {
      lat: Faker::Address.latitude,
      lon: Faker::Address.longitude
    }
  }

  es.index index: INDEX, type: 'user', id: user[:email], body: user
end
