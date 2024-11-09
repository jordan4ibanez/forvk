module vulkan_driver_create_validation_layers
  use, intrinsic :: iso_c_binding
  use :: vector
  implicit none


contains


  subroutine create_required_validation_layers(required_validation_layers, DEBUG_MODE)
    implicit none

    ! const char *
    type(vec), intent(inout) :: required_validation_layers
    logical(c_bool), intent(in), value :: DEBUG_MODE
    character(len = :, kind = c_char), pointer :: layer_name

    ! If we're not in debug mode, don't bother with this.
    if (.not. DEBUG_MODE) then
      return
    end if

    ! Create validation layers that we need.

    print"(A)","[Vulkan]: Creating required validation layers."

    layer_name => null()
    required_validation_layers = new_vec(sizeof(c_null_ptr), 0_8)

    allocate(character(len = 28, kind = c_char) :: layer_name)
    layer_name = "VK_LAYER_KHRONOS_validation"//achar(0)
    call required_validation_layers%push_back(c_loc(layer_name))
  end subroutine create_required_validation_layers



end module vulkan_driver_create_validation_layers
