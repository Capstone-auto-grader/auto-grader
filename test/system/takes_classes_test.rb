require "application_system_test_case"

class TakesClassesTest < ApplicationSystemTestCase
  setup do
    @takes_class = takes_classes(:one)
  end

  test "visiting the index" do
    visit takes_classes_url
    assert_selector "h1", text: "Takes Classes"
  end

  test "creating a Takes class" do
    visit takes_classes_url
    click_on "New Takes Class"

    click_on "Create Takes class"

    assert_text "Takes class was successfully created"
    click_on "Back"
  end

  test "updating a Takes class" do
    visit takes_classes_url
    click_on "Edit", match: :first

    click_on "Update Takes class"

    assert_text "Takes class was successfully updated"
    click_on "Back"
  end

  test "destroying a Takes class" do
    visit takes_classes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Takes class was successfully destroyed"
  end
end
