module vulkan_driver_create_surface
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_surface(vulkan_instance, window_surface)
    implicit none

    ! VkInstance
    integer(c_int64_t), intent(in), value :: vulkan_instance
    ! VkSurfaceKHR
    integer(c_int64_t), intent(inout) :: window_surface
    type(c_ptr) :: window_pointer

    window_pointer = glfw_get_window_pointer()

    if (glfw_create_window_surface(vulkan_instance, window_pointer, c_null_ptr, window_surface) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create window surface."
    end if
  end subroutine create_surface


end module vulkan_driver_create_surface
