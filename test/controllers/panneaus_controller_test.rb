require 'test_helper'

class PanneausControllerTest < ActionDispatch::IntegrationTest
  setup do
    @panneau = panneaus(:one)
  end

  test "should get index" do
    get panneaus_url
    assert_response :success
  end

  test "should get new" do
    get new_panneau_url
    assert_response :success
  end

  test "should create panneau" do
    assert_difference('Panneau.count') do
      post panneaus_url, params: { panneau: { is_ok: @panneau.is_ok, lat: @panneau.lat, long: @panneau.long, name: @panneau.name, ville: @panneau.ville } }
    end

    assert_redirected_to panneau_url(Panneau.last)
  end

  test "should show panneau" do
    get panneau_url(@panneau)
    assert_response :success
  end

  test "should get edit" do
    get edit_panneau_url(@panneau)
    assert_response :success
  end

  test "should update panneau" do
    patch panneau_url(@panneau), params: { panneau: { is_ok: @panneau.is_ok, lat: @panneau.lat, long: @panneau.long, name: @panneau.name, ville: @panneau.ville } }
    assert_redirected_to panneau_url(@panneau)
  end

  test "should destroy panneau" do
    assert_difference('Panneau.count', -1) do
      delete panneau_url(@panneau)
    end

    assert_redirected_to panneaus_url
  end
end
