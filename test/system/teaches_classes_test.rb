require "application_system_test_case"

class TeachesClassesTest < ApplicationSystemTestCase
  setup do
    @teaches_class = teaches_classes(:one)
  end

  test "visiting the index" do
    visit teaches_classes_url
    assert_selector "h1", text: "Teaches Classes"
  end

  test "creating a Teaches class" do
    visit teaches_classes_url
    click_on "New Teaches Class"

    click_on "Create Teaches class"

    assert_text "Teaches class was successfully created"
    click_on "Back"
  end

  test "updating a Teaches class" do
    visit teaches_classes_url
    click_on "Edit", match: :first

    click_on "Update Teaches class"

    assert_text "Teaches class was successfully updated"
    click_on "Back"
  end

  test "destroying a Teaches class" do
    visit teaches_classes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Teaches class was successfully destroyed"
  end
end
