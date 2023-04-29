# frozen_string_literal: true

# Base class for all controllers
class BaseController < ApplicationController
  def index
    render plain: 'OK'
  end
end
