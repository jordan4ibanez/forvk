program main
  use forvk, only: say_hello
  use :: glfw
  implicit none

  if (.not. glfw_create_window(500, 500, "forvk")) then

  end if
end program main
