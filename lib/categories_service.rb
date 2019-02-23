require_relative 'service_helpers'

# Operations on categories
class CategoriesService

  ITEM_MAPPER = proc do |doc|
    {
      id: doc[:id],
      title: doc[:title],
      description: doc[:description],
      parent_id: doc[:parent_id],
    }
  end

  def initialize
    @db = Database.instance
    @categories = DBOperations.new(@db).categories
  end

  def get(id)
    category_doc = check(@categories.find_one(id))
    raise ObjectNotFound, "Category with id=#{id} is not found" if category_doc.nil?

    category_oid = category_doc[:id]

    nested_categories = @categories.filter({parent_oid: category_oid}, {index: 1})
    category_doc[:categories] = nested_categories

    scripts = @db.scripts.find({category_oid: category_oid}).sort(index: 1).map do |doc|
      {
        id: doc[:id],
        index: doc[:index],
        number: doc[:number],
        title: doc[:title],
        description: doc[:description],
      }
    end
    category_doc[:scripts] = scripts
    category_doc
  end

  def all
    @categories.filter
  end

  def create(category)
    if non_empty_value? category, :parent_id
      parent_id = category[:parent_id].to_i
      parent = check(@coll.find(id: parent_id)).first
      if parent.nil?
        raise BadRequest, "Wrong parent id:  category with id=#{parent_id} is not exists"
      end
      parent_oid = parent[:_id]
    else
      parent_id = nil
      parent_oid = nil
    end

    key = @db.next_key_for(@coll)

    check(@coll.insert_one(
      id: key,
      parent_oid: parent_oid,
      parent_id: parent_id,
      title: category[:title],
      description: category[:description]
    ))
    {
      id: key,
      parent_id: parent_id,
      title: category[:title],
      description: category[:description]
    }
  end

  def delete(category_key)
    # TODO check, whether there are no scripts or other categories under the category
    check(@coll.delete_one(id: category_key.to_i))
    true
  end

  def update(category)
    raise 'key is not specified' unless non_empty_value? category, :id

    raise ObjectNotFound, 'Category not found' if @coll.find(id: id).count.zero?

    update_statement = build_update_statement(category, :title, :description, :parent_id)
    check(@coll.update_one({key: category[:key].to_i}, update_statement, upsert: false))
  end

  private

  include ServiceHelpers
end