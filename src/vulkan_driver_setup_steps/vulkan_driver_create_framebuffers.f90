module vulkan_driver_create_framebuffers
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vector
  implicit none


contains


  subroutine create_framebuffers(swapchain_framebuffers, swapchain_image_views, render_pass, swapchain_extent)
    implicit none

    ! VkFramebuffer
    type(vec), intent(inout) :: swapchain_framebuffers
    ! VkImageView
    type(vec), intent(inout) :: swapchain_image_views
    ! VkRenderPass
    integer(c_int64_t), intent(in), value :: render_pass
    ! VkExtent2D
    type(vk_extent_2d), intent(in) :: swapchain_extent
    integer(c_int64_t) :: i
    ! VkImageView
    integer(c_int64_t), dimension(1), target :: attachments
    integer(c_int64_t), pointer :: image_view
    type(vk_framebuffer_create_info), target :: frame_buffer_create_info

    swapchain_framebuffers = new_vec(sizeof(0_8), swapchain_image_views%size())
    call swapchain_image_views%resize(swapchain_image_views%size(), 0_8)

    do i = 1,swapchain_framebuffers%size()
      call c_f_pointer(swapchain_image_views%get(i), image_view)
      attachments(i) = image_view

      frame_buffer_create_info%s_type = VK_STRUCTURE_TYPE%FRAMEBUFFER_CREATE_INFO
      frame_buffer_create_info%render_pass = render_pass
      frame_buffer_create_info%attachment_count = 1
      frame_buffer_create_info%p_attachments = c_loc(attachments)
      frame_buffer_create_info%width = swapchain_extent%width
      frame_buffer_create_info%height = swapchain_extent%height
      frame_buffer_create_info%layers = 1


    end do
  end subroutine create_framebuffers


end module vulkan_driver_create_framebuffers
