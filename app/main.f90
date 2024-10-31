program main
  use forvk
  use :: glfw
  use :: string_f90
  use :: matrix_4f
  use :: vector_3f
  use, intrinsic :: iso_c_binding
  implicit none

  integer(c_int), target :: extension_count
  type(mat4f) :: matrix
  type(vec3f) :: vec

  

  extension_count = 0

  if (vk_enumerate_instance_extension_properties(c_null_ptr, c_loc(extension_count), c_null_ptr) /= VK_SUCCESS) then
    print*,"Failed to enumerate extension properties."
  end if

  print"(A)","[Vulkan]: "//int_to_string(extension_count)//" extensions supported."

  call matrix%identity()

  vec = [1.0, 2.0, 3.0]

  call matrix%translate_vec3f(vec)


  do while(.not. glfw_window_should_close())
    call glfw_poll_events()
  end do


  call glfw_destroy_window()

  call glfw_terminate()
end program main
