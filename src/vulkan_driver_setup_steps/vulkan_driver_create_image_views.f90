module vulkan_driver_create_image_views
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  use :: string_f90
  implicit none


contains


  subroutine create_image_views(logical_device, swapchain_images, swapchain_image_views, swapchain_image_format)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkImage Array
    type(vec), intent(inout) :: swapchain_images
    ! VkImageView Array
    type(vec), intent(inout) :: swapchain_image_views
    ! VkFormat
    integer(c_int32_t), intent(in), value :: swapchain_image_format
    integer(c_int64_t) :: i
    integer(c_int64_t), pointer :: image_pointer
    type(vk_image_view_create_info), pointer :: create_info

    swapchain_image_views = new_vec(sizeof(0_8), 0_8)
    call swapchain_image_views%resize(swapchain_images%size(), 0_8)

    do i = 1,swapchain_images%size()
      allocate(create_info)
      create_info%s_type = VK_STRUCTURE_TYPE%IMAGE%VIEW_CREATE_INFO

      call c_f_pointer(swapchain_images%get(i), image_pointer)
      create_info%image = image_pointer

      create_info%view_type = VK_IMAGE_VIEW_TYPE_2D
      create_info%format = swapchain_image_format

      create_info%components%r = VK_COMPONENT_SWIZZLE_IDENTITY
      create_info%components%g = VK_COMPONENT_SWIZZLE_IDENTITY
      create_info%components%b = VK_COMPONENT_SWIZZLE_IDENTITY
      create_info%components%a = VK_COMPONENT_SWIZZLE_IDENTITY

      create_info%subresource_range%aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT
      create_info%subresource_range%base_mip_level = 0
      create_info%subresource_range%level_count = 1
      create_info%subresource_range%base_array_layer = 0
      create_info%subresource_range%layer_count = 1

      if (vk_create_image_view(logical_device, c_loc(create_info), c_null_ptr, swapchain_image_views%get(i)) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create image view. Index ["//int64_to_string(i)//"]"
      end if
    end do
  end subroutine create_image_views


end module vulkan_driver_create_image_views
