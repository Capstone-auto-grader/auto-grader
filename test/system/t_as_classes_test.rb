require "application_system_test_case"

class TAsClassesTest < ApplicationSystemTestCase
  setup do
    @t_as_class = t_as_classes(:one)
  end

  test "visiting the index" do
    visit t_as_classes_url
    assert_selector "h1", text: "T As Classes"
  end

  test "creating a T as class" do
    visit t_as_classes_url
    click_on "New T As Class"

    click_on "Create T as class"

    assert_text "T as class was successfully created"
    click_on "Back"
  end

  test "updating a T as class" do
    visit t_as_classes_url
    click_on "Edit", match: :first

    click_on "Update T as class"

    assert_text "T as class was successfully updated"
    click_on "Back"
  end

  test "destroying a T as class" do
    visit t_as_classes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "T as class was successfully destroyed"
  end
end
