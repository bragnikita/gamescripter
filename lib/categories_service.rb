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

  def get(id = "")
    if id == ""
      category_doc = Category.where(title: "root", parent_id: nil).first
    else
      category_doc = Category.find(id)
    end
    nested_categories = category_doc.children
    hash = category_doc.as_json
    hash[:children] = nested_categories.map(&:as_json)
    hash[:scripts] = category_doc.scripts.map { |s| s.as_json(except: [:source, :html])}
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
    Category.create!(category
                       .slice(:title,
                              :subtitle,
                              :description,
                              :content_type,
                              :resources_prefix,
                              :parent_id)
                       .merge({
                                meta: { :story_type => category[:story_type] }
                              }))
  end

  def update(id, category)
    c = Category.find(id)
    cm = category.slice(:title,
                        :subtitle,
                        :description,
                        :content_type,
                        :resources_prefix)
    meta = c.meta ? c.meta.deep_merge(category.fetch(:meta, {})) : category.meta
    cm[:meta] = meta
    c.update_attributes!(cm)
  end

  def delete(id)
    Category.find(id).destroy!
  end

  def filter_category(filter = {})
    Category.where(filter).order_by(index: 1).map(&:as_json)
  end

  def create_category_view(category_id)
    if category_id == ""
      category_doc = Category.where(title: "root", parent_id: nil).first
    else
      category_doc = Category.find(category_id)
    end

    nested_categories = category_doc.children
    hash = category_doc.as_json
    hash[:children] = nested_categories.map(&:as_json)
    hash[:scripts] = category_doc.scripts.sort_by(&:index).map { |s| s.as_json(except: [:source])}
    hash

  end

  private

  include ServiceHelpers
end
