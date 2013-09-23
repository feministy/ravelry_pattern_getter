require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'
# require 'json/ext'
require 'curb'

include Mongo

configure do
  CONNECTION = MongoClient.new("localhost", 27017)
  set :mongo_connection, CONNECTION
  set :mongo_db, CONNECTION.db('feministy')
end

c = Curl::Easy.new("https://api.ravelry.com/patterns/419443.json")
c.http_auth_types = :basic
c.username = ENV['RAV_ACCESS_KEY']
c.password = ENV['RAV_PERSONAL_KEY']
c.perform

result = JSON.parse(c.body_str)
new_id = settings.mongo_db['test'].insert(result)

get '/collections/?' do
  settings.mongo_db.collection_names
end

# list all documents in the test collection
get '/documents/?' do
  content_type :json
  settings.mongo_db['test'].find.to_a.to_json
end

# find a document by its ID
get '/document/:id/?' do
  content_type :json
  document_by_id(params[:id]).to_json
end

# insert a new document from the request parameters,
# then return the full document
post '/new_document/?' do
  content_type :json
  new_id = settings.mongo_db['test'].insert params
  document_by_id(new_id).to_json
end

# # update the document specified by :id, setting its
# # contents to params, then return the full document
# put '/update/:id/?' do
#   content_type :json
#   id = object_id(params[:id])
#   settings.mongo_db['test'].update(:_id => id, params)
#   document_by_id(id).to_json
# end

# # update the document specified by :id, setting just its
# # name attribute to params[:name], then return the full
# # document
# put '/update_name/:id/?' do
#   content_type :json
#   id   = object_id(params[:id])
#   name = params[:name]
#   settings.mongo_db['test'].
#     update(:_id => id, {"$set" => {:name => name}})
#   document_by_id(id).to_json
# end

# # delete the specified document and return success
# delete '/remove/:id' do
#   content_type :json
#   settings.mongo_db['test'].
#     remove(:_id => object_id(params[:id]))
#   {:success => true}.to_json
# end