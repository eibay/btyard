defmodule Btyard.SoapServiceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Btyard.SoapService` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name"
      })
      |> Btyard.SoapService.create_user()

    user
  end
end
