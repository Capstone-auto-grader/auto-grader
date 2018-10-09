require 'test_helper'

class TAsClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @t_as_class = t_as_classes(:one)
  end

  test "should get index" do
    get t_as_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_t_as_class_url
    assert_response :success
  end

  test "should create t_as_class" do
    assert_difference('TAsClass.count') do
      post t_as_classes_url, params: { t_as_class: {  } }
    end

    assert_redirected_to t_as_class_url(TAsClass.last)
  end

  test "should show t_as_class" do
    get t_as_class_url(@t_as_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_t_as_class_url(@t_as_class)
    assert_response :success
  end

  test "should update t_as_class" do
    patch t_as_class_url(@t_as_class), params: { t_as_class: {  } }
    assert_redirected_to t_as_class_url(@t_as_class)
  end

  test "should destroy t_as_class" do
    assert_difference('TAsClass.count', -1) do
      delete t_as_class_url(@t_as_class)
    end

    assert_redirected_to t_as_classes_url
  end
end
