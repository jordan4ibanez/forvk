module vulkan_driver_create_descriptor_sets
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  subroutine create_descriptor_sets(descriptor_set_layout, MAX_FRAMES_IN_FLIGHT)
    implicit none

    type(vk_descriptor_set_layout), intent(in), value :: descriptor_set_layout
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! Vk DescriptorSetLayout
    type(vec) :: layouts

    layouts = new_vec(sizeof(descriptor_set_layout), MAX_FRAMES_IN_FLIGHT)
    call layouts%resize(MAX_FRAMES_IN_FLIGHT, descriptor_set_layout)

    

  end subroutine create_descriptor_sets


end module vulkan_driver_create_descriptor_sets
