module vulkan_driver_create_render_pass
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains

  subroutine create_render_pass(logical_device, render_pass, swapchain_image_format)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkRenderPass
    integer(c_int64_t), intent(inout) :: render_pass
    ! VkFormat
    integer(c_int32_t), intent(in), value :: swapchain_image_format
    type(vk_attachment_description), target :: color_attachment_description
    type(vk_attachment_reference), target :: color_attachment_reference
    type(vk_subpass_description_t), target :: subpass
    type(vk_render_pass_create_info), target  :: render_pass_create_info
    type(vk_subpass_dependency), target :: dependency

    color_attachment_description%format = swapchain_image_format
    color_attachment_description%samples = VK_SAMPLE_COUNT_1_BIT
    color_attachment_description%load_op = VK_ATTACHMENT_LOAD_OP_CLEAR
    color_attachment_description%store_op = VK_ATTACHMENT_STORE_OP_STORE
    color_attachment_description%stencil_load_op = VK_ATTACHMENT_LOAD_OP_DONT_CARE
    color_attachment_description%stencil_store_op = VK_ATTACHMENT_STORE_OP_DONT_CARE
    color_attachment_description%initial_layout = VK_IMAGE_LAYOUT_UNDEFINED
    color_attachment_description%final_layout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR

    color_attachment_reference%attachment = 0
    color_attachment_reference%layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL

    subpass%pipeline_bind_point = VK_PIPELINE_BIND_POINT_GRAPHICS
    subpass%color_attachment_count = 1
    subpass%p_color_attachments = c_loc(color_attachment_reference)

    dependency%src_subpass = VK_SUBPASS_EXTERNAL
    dependency%dst_subpass = 0
    dependency%src_stage_mask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    dependency%src_access_mask = 0
    dependency%dst_stage_mask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    dependency%dst_access_mask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT

    render_pass_create_info%s_type = VK_STRUCTURE_TYPE%RENDER_PASS_CREATE_INFO
    render_pass_create_info%attachment_count = 1
    render_pass_create_info%p_attachments = c_loc(color_attachment_description)
    render_pass_create_info%subpass_count = 1
    render_pass_create_info%p_subpasses = c_loc(subpass)
    render_pass_create_info%dependency_count = 1
    render_pass_create_info%p_dependencies = c_loc(dependency)

    if (vk_create_render_pass(logical_device, c_loc(render_pass_create_info), c_null_ptr, render_pass) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create render pass."
    end if
  end subroutine create_render_pass

end module vulkan_driver_create_render_pass
