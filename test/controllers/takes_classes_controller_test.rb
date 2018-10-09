require 'test_helper'

class TakesClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @takes_class = takes_classes(:one)
  end

  test "should get index" do
    get takes_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_takes_class_url
    assert_response :success
  end

  test "should create takes_class" do
    assert_difference('TakesClass.count') do
      post takes_classes_url, params: { takes_class: {  } }
    end

    assert_redirected_to takes_class_url(TakesClass.last)
  end

  test "should show takes_class" do
    get takes_class_url(@takes_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_takes_class_url(@takes_class)
    assert_response :success
  end

  test "should update takes_class" do
    patch takes_class_url(@takes_class), params: { takes_class: {  } }
    assert_redirected_to takes_class_url(@takes_class)
  end

  test "should destroy takes_class" do
    assert_difference('TakesClass.count', -1) do
      delete takes_class_url(@takes_class)
    end

    assert_redirected_to takes_classes_url
  end
end
