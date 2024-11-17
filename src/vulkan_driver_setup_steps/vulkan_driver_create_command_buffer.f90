module vulkan_driver_create_command_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_command_buffer(command_pool)
    implicit none

    
    type(vk_command_buffer_allocate_info), target :: command_buffer_allocate_info

    command_buffer_allocate_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    command_buffer_allocate_info%command_pool = command_pool
    command_buffer_allocate_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    command_buffer_allocate_info%command_buffer_count = 1

  end subroutine create_command_buffer


end module vulkan_driver_create_command_buffer
