# frozen_string_literal: true

require "plugin_helpers"
require "generators/generators_test_helper"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

module Unknown
  module Generators
  end
end

class ScaffoldControllerGeneratorTest < Rails::Generators::TestCase
  include PluginHelpers
  include GeneratorsTestHelper
  arguments %w(User name:string age:integer)

  setup :copy_routes

  def test_top_level_model
    run_generator ["User"]
    assert_file "app/controllers/users_controller.rb" do |content|
      assert_match "# GET /users", content
      assert_instance_method :index, content do |m|
        assert_match("@users = User.all", m)
      end

      assert_match "# POST /users", content
      assert_instance_method :create, content do |m|
        assert_match("redirect_to @user", m)
      end

      assert_match "# PATCH/PUT /users/1", content
      assert_instance_method :update, content do |m|
        assert_match("redirect_to @user", m)
      end
    end

    assert_file "app/views/users/index.html.erb" do |content|
      assert_match %{@users.each do |user|}, content
      assert_match %{render user}, content
      assert_match %{"Show this user", user}, content
      assert_match %{"New user", new_user_path}, content
    end

    assert_file "app/views/users/show.html.erb" do |content|
      assert_match %{render @user}, content
      assert_match %{"Edit this user", edit_user_path(@user)}, content
      assert_match %{"Back to users", users_path}, content
      assert_match %{"Destroy this user", @user}, content
    end

    assert_file "app/views/users/_user.html.erb" do |content|
      assert_match "user", content
    end

    assert_file "app/views/users/new.html.erb" do |content|
      assert_match %{render "form", user: @user}, content
      assert_match %{"Back to users", users_path}, content
    end

    assert_file "app/views/users/edit.html.erb" do |content|
      assert_match %{render "form", user: @user}, content
      assert_match %{"Show this user", @user}, content
      assert_match %{"Back to users", users_path}, content
    end

    assert_file "app/views/users/_form.html.erb" do |content|
      assert_match %{model: user}, content
    end

    assert_file "test/controllers/users_controller_test.rb" do |content|
      assert_match " users_url", content
      assert_match " new_user_url", content
      assert_match " edit_user_url", content
      assert_match " user_url(@user)", content
    end

    assert_file "test/system/users_test.rb"
  end

  def test_namespaced_model
    run_generator ["Admin::User"]
    assert_file "app/controllers/admin/users_controller.rb" do |content|
      assert_match "# GET /admin/users", content
      assert_instance_method :index, content do |m|
        assert_match("@admin_users = Admin::User.all", m)
      end

      assert_match "# POST /admin/users", content
      assert_instance_method :create, content do |m|
        assert_match("redirect_to @admin_user", m)
      end

      assert_match "# PATCH/PUT /admin/users/1", content
      assert_instance_method :update, content do |m|
        assert_match("redirect_to @admin_user", m)
      end
    end

    assert_file "app/views/admin/users/index.html.erb" do |content|
      assert_match %{@admin_users.each do |admin_user|}, content
      assert_match %{render admin_user}, content
      assert_match %{"Show this user", admin_user}, content
      assert_match %{"New user", new_admin_user_path}, content
    end

    assert_file "app/views/admin/users/show.html.erb" do |content|
      assert_match %{render @admin_user}, content
      assert_match %{"Edit this user", edit_admin_user_path(@admin_user)}, content
      assert_match %{"Back to users", admin_users_path}, content
      assert_match %{"Destroy this user", @admin_user}, content
    end

    assert_file "app/views/admin/users/_user.html.erb" do |content|
      assert_match "user", content
      assert_no_match "admin_user", content
    end

    assert_file "app/views/admin/users/new.html.erb" do |content|
      assert_match %{render "form", admin_user: @admin_user}, content
      assert_match %{"Back to users", admin_users_path}, content
    end

    assert_file "app/views/admin/users/edit.html.erb" do |content|
      assert_match %{render "form", admin_user: @admin_user}, content
      assert_match %{"Show this user", @admin_user}, content
      assert_match %{"Back to users", admin_users_path}, content
    end

    assert_file "app/views/admin/users/_form.html.erb" do |content|
      assert_match %{model: admin_user}, content
    end

    assert_file "test/controllers/admin/users_controller_test.rb" do |content|
      assert_match " admin_users_url", content
      assert_match " new_admin_user_url", content
      assert_match " edit_admin_user_url", content
      assert_match " admin_user_url(@admin_user)", content
      assert_no_match %r/\b(new_|edit_)?users?_(path|url)/, content
    end

    assert_file "test/system/admin/users_test.rb"
  end


  def test_top_level_model_with_top_level_model_name_option
    run_generator ["User", "--model-name=Person"]
    assert_file "app/controllers/users_controller.rb" do |content|
      assert_match "# GET /users", content
      assert_instance_method :index, content do |m|
        assert_match("@people = Person.all", m)
      end

      assert_match "# POST /users", content
      assert_instance_method :create, content do |m|
        assert_match("redirect_to user_path(@person)", m)
      end

      assert_match "# PATCH/PUT /users/1", content
      assert_instance_method :update, content do |m|
        assert_match("redirect_to user_path(@person)", m)
      end
    end

    assert_file "app/views/users/index.html.erb" do |content|
      assert_match %{@people.each do |person|}, content
      assert_match %{render "user", person: person}, content
      assert_match %{"Show this person", user_path(person)}, content
      assert_match %{"New person", new_user_path}, content
    end

    assert_file "app/views/users/show.html.erb" do |content|
      assert_match %{render "user", person: @person}, content
      assert_match %{"Edit this person", edit_user_path(@person)}, content
      assert_match %{"Back to people", users_path}, content
      assert_match %{"Destroy this person", user_path(@person)}, content
    end

    assert_file "app/views/users/_user.html.erb" do |content|
      assert_match "person", content
      assert_no_match "user", content
    end

    assert_file "app/views/users/new.html.erb" do |content|
      assert_match %{render "form", person: @person}, content
      assert_match %{"Back to people", users_path}, content
    end

    assert_file "app/views/users/edit.html.erb" do |content|
      assert_match %{render "form", person: @person}, content
      assert_match %{"Show this person", user_path(@person)}, content
      assert_match %{"Back to people", users_path}, content
    end

    assert_file "app/views/users/_form.html.erb" do |content|
      assert_match %{model: person}, content
    end

    assert_file "test/controllers/users_controller_test.rb" do |content|
      assert_match " users_url", content
      assert_match " new_user_url", content
      assert_match " edit_user_url", content
      assert_match " user_url(@person)", content
      assert_no_match %r/\b(new_|edit_)?people?_(path|url)/, content
    end

    assert_file "test/system/users_test.rb"
  end

  def test_namespaced_model_with_top_level_model_name_option
    run_generator ["Admin::User", "--model-name=Person"]
    assert_file "app/controllers/admin/users_controller.rb" do |content|
      assert_match "# GET /admin/users", content
      assert_instance_method :index, content do |m|
        assert_match("@people = Person.all", m)
      end

      assert_match "# POST /admin/users", content
      assert_instance_method :create, content do |m|
        # assert_match("redirect_to [:admin, @person]", m)
        assert_match("redirect_to admin_user_path(@person)", m)
      end

      assert_match "# PATCH/PUT /admin/users/1", content
      assert_instance_method :update, content do |m|
        # assert_match("redirect_to [:admin, @person]", m)
        assert_match("redirect_to admin_user_path(@person)", m)
      end
    end

    assert_file "app/views/admin/users/index.html.erb" do |content|
      assert_match %{@people.each do |person|}, content
      assert_match %{render "user", person: person}, content
      # assert_match %{"Show this person", [:admin, person]}, content # TODO: Need to test this in test app.
      assert_match %{"Show this person", admin_user_path(person)}, content
      assert_match %{"New person", new_admin_user_path}, content
    end

    assert_file "app/views/admin/users/show.html.erb" do |content|
      assert_match %{render "user", person: @person}, content
      assert_match %{"Edit this person", edit_admin_user_path(@person)}, content
      assert_match %{"Back to people", admin_users_path}, content
      # assert_match %{"Destroy this person", [:admin, @person]}, content
      assert_match %{"Destroy this person", admin_user_path(@person)}, content
    end

    assert_file "app/views/admin/users/_user.html.erb" do |content|
      assert_match "person", content
      assert_no_match "user", content
    end

    assert_file "app/views/admin/users/new.html.erb" do |content|
      assert_match %{render "form", person: @person}, content
      assert_match %{"Back to people", admin_users_path}, content
    end

    assert_file "app/views/admin/users/edit.html.erb" do |content|
      assert_match %{render "form", person: @person}, content
      assert_match %{"Show this person", admin_user_path(@person)}, content
      assert_match %{"Back to people", admin_users_path}, content
    end

    assert_file "app/views/admin/users/_form.html.erb" do |content|
      # assert_match %{model: [:admin, person]}, content
      assert_match %{model: person, url: admin_users_path}, content
    end

    assert_file "test/controllers/admin/users_controller_test.rb" do |content|
      assert_match " admin_users_url", content
      assert_match " new_admin_user_url", content
      assert_match " edit_admin_user_url", content
      assert_match " admin_user_url(@person)", content
      assert_no_match %r/\b(new_|edit_)?people?_(path|url)/, content
    end

    assert_file "test/system/admin/users_test.rb" # Checked and matches current Rails behavior.
  end

  def test_top_level_model_with_namespaced_model_name_option
    # TODO
    # run_generator ["Person", "--model-name=Admin::User"]

    run_generator ["Person", "--model-name=Admin::User"]
    assert_file "app/controllers/people_controller.rb" do |content|
      assert_match "# GET /people", content
      assert_instance_method :index, content do |m|
        assert_match("@admin_users = Admin::User.all", m)
      end

      assert_match "# POST /people", content
      assert_instance_method :create, content do |m|
        assert_match("redirect_to person_path(@admin_user)", m)
      end

      assert_match "# PATCH/PUT /people/1", content
      assert_instance_method :update, content do |m|
        assert_match("redirect_to person_path(@admin_user)", m)
      end
    end

    assert_file "app/views/people/index.html.erb" do |content|
      assert_match %{@admin_users.each do |admin_user|}, content
      assert_match %{render "person", admin_user: admin_user}, content
      assert_match %{"Show this user", person_path(admin_user)}, content
      assert_match %{"New user", new_person_path}, content
    end

    assert_file "app/views/people/show.html.erb" do |content|
      assert_match %{render "person", admin_user: @admin_user}, content
      assert_match %{"Edit this user", edit_person_path(@admin_user)}, content
      assert_match %{"Back to users", people_path}, content
      assert_match %{"Destroy this user", person_path(@admin_user)}, content
    end

    assert_file "app/views/people/_person.html.erb" do |content|
      assert_match "user", content
      assert_no_match "person", content
    end

    assert_file "app/views/people/new.html.erb" do |content|
      assert_match %{render "form", admin_user: @admin_user}, content
      assert_match %{"Back to users", people_path}, content
    end

    assert_file "app/views/people/edit.html.erb" do |content|
      assert_match %{render "form", admin_user: @admin_user}, content
      assert_match %{"Show this user", person_path(@admin_user)}, content
      assert_match %{"Back to users", people_path}, content
    end

    assert_file "app/views/people/_form.html.erb" do |content|
      assert_match %{model: admin_user, url: people_path}, content
    end

    assert_file "test/controllers/people_controller_test.rb" do |content|
      assert_match " people_url", content
      assert_match " new_person_url", content
      assert_match " edit_person_url", content
      assert_match " person_url(@admin_user)", content
      assert_no_match %r/\b(new_|edit_)?admin_user?_(path|url)/, content
    end

    assert_file "test/system/people_test.rb" # Checked and matches current Rails behavior.
  end

  def test_namespaced_model_with_namespaced_model_name_option
    # TODO
    # run_generator ["Customer::Person", "--model-name=Admin::User"]


    run_generator ["Customer::Person", "--model-name=Admin::User"]
    assert_file "app/controllers/customer/people_controller.rb" do |content|
      assert_match "# GET /customer/people", content
      assert_instance_method :index, content do |m|
        assert_match("@admin_users = Admin::User.all", m)
      end

      assert_match "# POST /customer/people", content
      assert_instance_method :create, content do |m|
        assert_match("redirect_to customer_person_path(@admin_user)", m)
      end

      assert_match "# PATCH/PUT /customer/people/1", content
      assert_instance_method :update, content do |m|
        assert_match("redirect_to customer_person_path(@admin_user)", m)
      end
    end

    assert_file "app/views/customer/people/index.html.erb" do |content|
      assert_match %{@admin_users.each do |admin_user|}, content
      assert_match %{render "person", admin_user: admin_user}, content
      assert_match %{"Show this user", customer_person_path(admin_user)}, content
      assert_match %{"New user", new_customer_person_path}, content
    end

    assert_file "app/views/customer/people/show.html.erb" do |content|
      assert_match %{render "person", admin_user: @admin_user}, content
      assert_match %{"Edit this user", edit_customer_person_path(@admin_user)}, content
      assert_match %{"Back to users", customer_people_path}, content
      assert_match %{"Destroy this user", customer_person_path(@admin_user)}, content
    end

    assert_file "app/views/customer/people/_person.html.erb" do |content|
      assert_match "user", content
      assert_no_match "person", content
    end

    assert_file "app/views/customer/people/new.html.erb" do |content|
      assert_match %{render "form", admin_user: @admin_user}, content
      assert_match %{"Back to users", customer_people_path}, content
    end

    assert_file "app/views/customer/people/edit.html.erb" do |content|
      assert_match %{render "form", admin_user: @admin_user}, content
      assert_match %{"Show this user", customer_person_path(@admin_user)}, content
      assert_match %{"Back to users", customer_people_path}, content
    end

    assert_file "app/views/customer/people/_form.html.erb" do |content|
      assert_match %{model: admin_user, url: customer_people_path}, content
    end

    assert_file "test/controllers/customer/people_controller_test.rb" do |content|
      assert_match " customer_people_url", content
      assert_match " new_customer_person_url", content
      assert_match " edit_customer_person_url", content
      assert_match " customer_person_url(@admin_user)", content
      assert_no_match %r/\b(new_|edit_)?admin_user?_(path|url)/, content
    end

    assert_file "test/system/customer/people_test.rb" # Checked and matches current Rails behavior.
  end
end
