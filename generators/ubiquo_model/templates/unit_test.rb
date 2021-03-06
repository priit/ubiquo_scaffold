require File.dirname(__FILE__) + '/../test_helper'

class <%= class_name %>Test < ActiveSupport::TestCase

  def test_should_create_<%= file_name %>
    assert_difference '<%= class_name %>.count' do
      <%= file_name %> = create_<%= file_name %>
      assert !<%= file_name %>.new_record?, "#{<%= file_name %>.errors.full_messages.to_sentence}"
    end
  end

  <%- unless ton.nil? -%>
  def test_should_require_<%= ton %>
    assert_no_difference '<%= class_name %>.count' do
      <%= file_name %> = create_<%= file_name %>(:<%= ton %> => "")
      assert <%= file_name %>.errors.on(:<%= ton %>)
    end
  end
  
  def test_should_filter_by_<%= ton %>
    <%= class_name %>.destroy_all
    <%= file_name %>_1,<%= file_name %>_2,<%= file_name %>_3 = [
      create_<%= file_name %>(:<%= ton %> => "try to find me"),
      create_<%= file_name %>(:<%= ton %> => "try to FinD me"),
      create_<%= file_name %>(:<%= ton %> => "I don't appear"),
    ]
    
    assert_equal_set [<%= file_name %>_1,<%= file_name %>_2], <%= class_name %>.filtered_search({:text => "find"})
  end
  <% end -%>

  <%- if has_published_at -%>
  def test_should_filter_by_publish_date
    <%= class_name %>.destroy_all
    <%= file_name %>_1,<%= file_name %>_2,<%= file_name %>_3 = [
      create_<%= file_name %>(:published_at => 5.day.ago),
      create_<%= file_name %>(:published_at => 10.days.ago),
      create_<%= file_name %>(:published_at => 5.days.from_now),
    ]
    
    assert_equal_set [], <%= class_name %>.filtered_search({:publish_start => 10.day.from_now})
    assert_equal_set [<%= file_name %>_3], <%= class_name %>.filtered_search({:publish_start => 3.day.ago})
    assert_equal_set [<%= file_name %>_1, <%= file_name %>_3], <%= class_name %>.filtered_search({:publish_start => 7.day.ago})
    assert_equal_set [<%= file_name %>_1, <%= file_name %>_2, <%= file_name %>_3], <%= class_name %>.filtered_search({:publish_start => 12.day.ago})
     
    assert_equal_set [], <%= class_name %>.filtered_search({:publish_end => 12.day.ago})
    assert_equal_set [<%= file_name %>_2], <%= class_name %>.filtered_search({:publish_end => 7.day.ago})
    assert_equal_set [<%= file_name %>_1, <%= file_name %>_2], <%= class_name %>.filtered_search({:publish_end => 3.day.ago})
    assert_equal_set [<%= file_name %>_1, <%= file_name %>_2, <%= file_name %>_3], <%= class_name %>.filtered_search({:publish_end => 10.day.from_now})
     
    assert_equal_set [<%= file_name %>_1], <%= class_name %>.filtered_search({:publish_start => 7.day.ago, :publish_end => 3.day.ago})
  end
  <%- end -%>
  private
  
  def create_<%= file_name %>(options = {})
    default_options = {
      <%- for attribute in attributes -%>
      :<%= attribute.name %> => '<%= attribute.default %>', # <%= attribute.type.to_s %>
      <%- end -%>
    }
    <%= class_name %>.create(default_options.merge(options))
  end
end
