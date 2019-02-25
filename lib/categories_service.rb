require_relative 'service_helpers'
require_relative 'models/category'

# Operations on categories
class CategoriesService

  def root
    Category.where(parent: nil).order_by(title: :asc)
  end

  def get_parents(id)
    category_doc = Category.find(id)
    upper_parents = []

    def add_parent(cat, arr)
      if cat.has_parent?
        arr << cat.parent
        add_parent(cat.parent, arr)
      end
    end

    add_parent(category_doc, upper_parents)
    upper_parents
  end

  def get(id)
    category_doc = Category.find(id)
    nested_categories = category_doc.children
    hash = category_doc.as_json
    hash[:children] = nested_categories.map(&:as_json)
    hash
  end

  def all
   Category.order_by(title: :asc)
  end

  def create(category)
    if category[:parent]
      unless Category.where(id: category[:parent]).exists?
        raise ObjectNotFound, 'Parent is not found'
      end
    end
    Category.create!(category)
  end

  def update(id, category)
    Category.find(id).update_attributes!(category)
  end

  def delete(id)
    Category.find(id).destroy!
  end

  private

  include ServiceHelpers
end