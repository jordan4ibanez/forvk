program main
  use forvk
  use :: glfw
  use, intrinsic :: iso_c_binding
  implicit none

  integer(c_int), target :: extension_count

  if (.not. glfw_init()) then
    error stop "Failed to initialize GLFW."
  end if

  call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)

  if (.not. glfw_create_window(500, 500, "forvk")) then
    error stop "Failed to create window."
  end if


  if (vk_enumerate_instance_extension_properties(c_null_ptr, c_loc(extension_count), c_null_ptr) /= VK_SUCCESS) then
    print*,"Failed to enumerate extension properties."
  end if


  call glfw_destroy_window()

  call glfw_terminate()
end program main
