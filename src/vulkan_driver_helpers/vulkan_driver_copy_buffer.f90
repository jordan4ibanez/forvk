module vulkan_driver_copy_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  subroutine copy_buffer(logical_device, src_buffer, dst_buffer, buffer_size, command_pool, graphics_queue)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vk_buffer), intent(in), value :: src_buffer, dst_buffer
    type(vk_device_size), intent(in), value :: buffer_size
    type(vk_command_pool), intent(in), value :: command_pool
    type(vk_queue), intent(in), value :: graphics_queue
    type(vk_command_buffer_allocate_info), target :: alloc_info
    type(vk_command_buffer), target :: command_buffer
    type(vk_command_buffer_begin_info), target :: begin_info
    type(vk_buffer_copy), target :: copy_region
    type(vk_submit_info), target :: submit_info

    alloc_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    alloc_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    alloc_info%command_pool = command_pool
    alloc_info%command_buffer_count = 1

    if (vk_allocate_command_buffers(logical_device, c_loc(alloc_info), c_loc(command_buffer)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate command buffer."
    end if

    begin_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_BEGIN_INFO
    begin_info%flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT

    if (vk_begin_command_buffer(command_buffer, c_loc(begin_info)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to start command buffer."
    end if

    copy_region%src_offset%data = 0
    copy_region%dst_offset%data = 0
    copy_region%size = buffer_size

    call vk_cmd_copy_buffer(command_buffer, src_buffer, dst_buffer, 1, c_loc(copy_region))

    if (vk_end_command_buffer(command_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to end command buffer."
    end if

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer)

    if (vk_queue_submit(graphics_queue, 1, c_loc(submit_info), vk_fence(VK_NULL_HANDLE)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to submit queue."
    end if

    if (vk_queue_wait_idle(graphics_queue) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait idle on queue."
    end if

    call vk_free_command_buffers(logical_device, command_pool, 1, c_loc(command_buffer))
  end subroutine


end module vulkan_driver_copy_buffer
