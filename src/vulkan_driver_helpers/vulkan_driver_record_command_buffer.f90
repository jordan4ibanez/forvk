module vulkan_driver_record_command_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  subroutine record_command_buffer(command_buffer, image_index, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline)
    implicit none

    ! VkCommandBuffer
    integer(c_int64_t), intent(in), value :: command_buffer
    ! uint32_t
    integer(c_int32_t), intent(in), value :: image_index
    type(vk_render_pass), intent(in), value :: render_pass
    ! VkFramebuffer
    type(vec), intent(inout) :: swapchain_framebuffers
    type(vk_extent_2d), intent(in) :: swapchain_extent
    type(vk_pipeline), intent(in), value :: graphics_pipeline
    type(vk_command_buffer_begin_info), target :: begin_info
    type(vk_render_pass_begin_info), target :: render_pass_info
    integer(c_int64_t), pointer :: framebuffer
    type(vk_clear_color_value_f32), target :: clear_color
    type(vk_viewport), target :: viewport
    type(vk_rect_2d), target :: scissor


    begin_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_BEGIN_INFO
    begin_info%flags = 0
    begin_info%p_inheritence_info = c_null_ptr

    if (vk_begin_command_buffer(command_buffer, c_loc(begin_info)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to begin recording command buffer."
    end if

    render_pass_info%s_type = VK_STRUCTURE_TYPE%RENDER_PASS_BEGIN_INFO
    render_pass_info%render_pass = render_pass
    call c_f_pointer(swapchain_framebuffers%get(int(image_index, c_int64_t)), framebuffer)
    render_pass_info%framebuffer = framebuffer
    render_pass_info%render_area%offset%x = 0
    render_pass_info%render_area%offset%y = 0
    render_pass_info%render_area%extent = swapchain_extent

    clear_color%data = [0.0, 0.0, 0.0, 1.0]
    render_pass_info%clear_value_count = 1
    render_pass_info%p_clear_values = c_loc(clear_color)

    call vk_cmd_begin_render_pass(command_buffer, c_loc(render_pass_info), VK_SUBPASS_CONTENTS_INLINE)

    call vk_cmd_bind_pipeline(command_buffer, VK_PIPELINE_BIND_POINT_GRAPHICS, graphics_pipeline)

    viewport%x = 0.0
    viewport%y = 0.0
    viewport%width = swapchain_extent%width
    viewport%height = swapchain_extent%height
    viewport%min_depth = 0.0
    viewport%max_depth = 1.0

    call vk_cmd_set_viewport(command_buffer, 0, 1, c_loc(viewport))

    scissor%offset%x = 0
    scissor%offset%y = 0
    scissor%extent = swapchain_extent

    call vk_cmd_set_scissor(command_buffer, 0, 1, c_loc(scissor))

    call vk_cmd_draw(command_buffer, 3, 1, 0, 0)

    call vk_cmd_end_render_pass(command_buffer)

    if (vk_end_command_buffer(command_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to record command buffer."
    end if

  end subroutine record_command_buffer


end module vulkan_driver_record_command_buffer
