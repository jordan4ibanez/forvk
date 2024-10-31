module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: forvk
  use :: glfw
  implicit none


  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.

contains

  subroutine run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine run


  subroutine init_vulkan()
    implicit none

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_FALSE)

    if (.not. glfw_create_window(500, 500, "forvk")) then
      error stop "[Vulkan]: Failed to create window."
    end if
  end subroutine init_vulkan


  subroutine main_loop()
    implicit none

  end subroutine main_loop


  subroutine clean_up()
    implicit none

  end subroutine clean_up


end module vulkan_driver
