# example model file
class Location
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String  
  property :lat,				String
  property :long,				String
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name
end
