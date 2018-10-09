require 'test_helper'

class TeachesClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teaches_class = teaches_classes(:one)
  end

  test "should get index" do
    get teaches_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_teaches_class_url
    assert_response :success
  end

  test "should create teaches_class" do
    assert_difference('TeachesClass.count') do
      post teaches_classes_url, params: { teaches_class: {  } }
    end

    assert_redirected_to teaches_class_url(TeachesClass.last)
  end

  test "should show teaches_class" do
    get teaches_class_url(@teaches_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_teaches_class_url(@teaches_class)
    assert_response :success
  end

  test "should update teaches_class" do
    patch teaches_class_url(@teaches_class), params: { teaches_class: {  } }
    assert_redirected_to teaches_class_url(@teaches_class)
  end

  test "should destroy teaches_class" do
    assert_difference('TeachesClass.count', -1) do
      delete teaches_class_url(@teaches_class)
    end

    assert_redirected_to teaches_classes_url
  end
end
