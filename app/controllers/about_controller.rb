class AboutController < ApplicationController
  before_action :set_body_classes

  def index
  end

  def terms
    @state = 'TBD'
  end

  private

  def set_body_classes
    @body_classes = 'about-body'
  end
end
