module vulkan_driver_create_command_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_command_buffers(logical_device, command_pool, command_buffer)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkCommandPool
    integer(c_int64_t), intent(in), value :: command_pool
    ! VkCommandBuffer
    integer(c_int64_t), intent(inout) :: command_buffer
    type(vk_command_buffer_allocate_info), target :: command_buffer_allocate_info

    command_buffer_allocate_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    command_buffer_allocate_info%command_pool = command_pool
    command_buffer_allocate_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    command_buffer_allocate_info%command_buffer_count = 1

    if (vk_allocate_command_buffers(logical_device, c_loc(command_buffer_allocate_info), command_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create command buffers."
    end if
  end subroutine create_command_buffers


end module vulkan_driver_create_command_buffer
