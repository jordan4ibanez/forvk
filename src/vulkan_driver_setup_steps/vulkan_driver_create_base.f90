module vulkan_driver_create_base
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: forvulkan_parameters
  use :: forvulkan
  implicit none


contains


  subroutine create_glfw()
    implicit none

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    ! call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_FALSE)

    if (.not. glfw_create_window(500, 500, "forvulkan")) then
      error stop "[Vulkan]: Failed to create window."
    end if
  end subroutine create_glfw


end module vulkan_driver_create_base
