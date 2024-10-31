module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: forvk
  use :: glfw
  use :: string_f90
  implicit none


  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.

contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


  subroutine init_vulkan()
    implicit none

    integer(c_int), target :: extension_count

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_FALSE)

    if (.not. glfw_create_window(500, 500, "forvk")) then
      error stop "[Vulkan]: Failed to create window."
    end if

    extension_count = 0

    if (vk_enumerate_instance_extension_properties(c_null_ptr, c_loc(extension_count), c_null_ptr) /= VK_SUCCESS) then
      print*,"Failed to enumerate extension properties."
    end if

    print"(A)","[Vulkan]: "//int_to_string(extension_count)//" extensions supported."
  end subroutine init_vulkan


  subroutine main_loop()
    implicit none

    do while(.not. glfw_window_should_close())
      call glfw_poll_events()
    end do

  end subroutine main_loop


  subroutine clean_up()
    implicit none

    call glfw_destroy_window()

    call glfw_terminate()
  end subroutine clean_up


end module vulkan_driver
