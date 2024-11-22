module vulkan_driver_create_base
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: forvulkan
  implicit none


  ! This is a trick to pass the mutable boolean to the framebuffer resize callback.
  type(c_ptr) :: resized_loc


contains

  subroutine create_glfw(framebuffer_resized)
    implicit none

    logical(c_bool), intent(inout), target :: framebuffer_resized

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    resized_loc = c_loc(framebuffer_resized)

    call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_TRUE)

    if (.not. glfw_create_window(500, 500, "forvulkan")) then
      error stop "[Vulkan]: Failed to create window."
    end if


    call glfw_set_framebuffer_size_callback(c_funloc(framebuffer_size_callback))
  end subroutine create_glfw


  recursive subroutine framebuffer_size_callback(window, width, height) bind(c)
    implicit none

    type(c_ptr), intent(in), value :: window
    integer(c_int32_t), intent(in), value :: width, height
    logical(c_bool), pointer :: framebuffer_resized_pointer

    if (.false.) then
      print*,window, width, height
    end if

    call c_f_pointer(resized_loc, framebuffer_resized_pointer)
    framebuffer_resized_pointer = .true.
  end subroutine framebuffer_size_callback

end module vulkan_driver_create_base
