class TagsController < ApplicationController

  skip_before_filter :require_login

  # commented to hide index
  #def index
  #  @tags = Tag.all
  #  render json: @tags
  #end

  def get_all
    @tags = Tag.all
    render json: @tags
  end

  def product_tags
    tags = []
    taggings = Tagging.live.includes(:draft).where(:taggable_id => params[:product_id])
    taggings.each do |tagging|
      tag_id = tagging.tag_id
      tag = Tag.find(tag_id)
      tag.taggings_count = Tagging.where(:tag_id => tag_id).count
      tag.save
      tags.push(tag)
    end
    render json: {tags: tags, redirect_url: "/product/#{params[:product_id]}"}
  end

  def product_tags_add
    if !current_user.present?
       render json: {status: "login", redirect_url: "/login"}
       return
     end
    id = Tag.maximum(:id).next
    tag = Tag.new(:id => id,
                  :name => params[:name],
                  :taggings_count => params[:count])
    tag.save
    tagging = Tagging.new(:tag_id => id,
                          :taggable_id => params[:product_id],
                          :tagger_id => current_user.id)
    tagging.save
    render json: tagging
  end

  def product_tags_edit
     if !current_user.present?
       render json: {status: "login", redirect_url: "/login"}
       return
     end
    tags = params["_json"]
    taggings = Tagging.where(:taggable_id => params[:product_id])
    taggings.delete_all
    if tags.present?
      tags.each do |tag|
      name = tag["name"]
      id = tag["id"]
      tagging = Tagging.new(:tag_id => tag["id"],
                            :taggable_id => params[:product_id],
                            :tagger_id => current_user.id)
       tagging.save
      end
     product_tags
    else
      render json: {tags: tags, redirect_url: "/product/#{params[:product_id]}"}
    end
  end

  def tagging_count
    tags = Tagging.where(:tag_id => params[:tag_id])
    render json: tags.count 
  end

  def tags_add
    tags = params["_json"]
    if tags.present?
      tags.each do |tag|
      tagging =  Tagging.new(:tag_id => tag["id"],
                            :taggable_id => params[:product_id],
                            :tagger_id => current_user.id)
      tagging.draft_creation
      end
    end
    render json: params
  end

  def tags_delete
    tags = params["_json"]
    if tags.present?
      tags.each do |tag|
        tagging = Tagging.where(:tag_id => tag["id"], :taggable_id => params[:product_id]).first
        tagging.draft_destroy
      end
    end
    render json: params
  end

end
