module vulkan_driver_recreate_swapchain
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_driver_create_swapchain
  use :: vulkan_driver_create_image_views
  use :: vulkan_driver_create_framebuffers
  use :: vulkan_driver_clean_up_swapchain
  use :: vector
  implicit none


contains


  subroutine recreate_swapchain(logical_device, physical_device, window_surface, swapchain, swapchain_images, swapchain_image_format, swapchain_extent, swapchain_image_views, swapchain_framebuffers, render_pass)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_surface_khr), intent(in), value :: window_surface
    type(vk_swapchain_khr), intent(inout) :: swapchain
    ! Vk Image Vector
    type(vec), intent(inout) :: swapchain_images
    type(vk_format), intent(inout) :: swapchain_image_format
    type(vk_extent_2d), intent(inout) :: swapchain_extent
    ! Vk ImageView Vector
    type(vec), intent(inout) :: swapchain_image_views
    ! Vk Framebuffer Vector
    type(vec), intent(inout) :: swapchain_framebuffers
    type(vk_render_pass), intent(in) :: render_pass

    if (vk_device_wait_idle(logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait for logical device."
    end if

    call clean_up_swapchain(logical_device, swapchain_framebuffers, swapchain_image_views, swapchain)

    call create_swapchain(physical_device, logical_device, window_surface, swapchain, swapchain_images, swapchain_image_format, swapchain_extent)
    call create_image_views(logical_device, swapchain_images, swapchain_image_views, swapchain_image_format)
    call create_framebuffers(logical_device, swapchain_framebuffers, swapchain_image_views, render_pass, swapchain_extent)

  end subroutine recreate_swapchain


end module vulkan_driver_recreate_swapchain
