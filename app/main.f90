program main
  use forvk, only: say_hello
  use :: glfw
  implicit none

  if (.not. glfw_init()) then
    error stop "Failed to initialize GLFW."
  end if

  call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)

  if (.not. glfw_create_window(500, 500, "forvk")) then
    error stop "Failed to create window."
  end if

  call glfw_destroy_window()

  call glfw_terminate()
end program main
