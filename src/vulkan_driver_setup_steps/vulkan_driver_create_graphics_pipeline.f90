module vulkan_driver_create_graphics_pipeline
  use, intrinsic :: iso_c_binding
  use :: vulkan_shader_compiler
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_graphics_pipeline(logical_device, vertex_shader_module, fragment_shader_module, swapchain_extent, pipeline_layout)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkShaderModule
    integer(c_int64_t), intent(inout) :: vertex_shader_module
    ! VkShaderModule
    integer(c_int64_t), intent(inout) :: fragment_shader_module
    ! VkExtent2D
    type(vk_extent_2d), intent(in) :: swapchain_extent
    ! VkPipelineLayout
    integer(c_int64_t), intent(inout) :: pipeline_layout
    type(vk_pipeline_shader_stage_create_info) :: vertex_shader_stage_info, fragment_shader_stage_info
    character(len = 5, kind = c_char), target :: vert_p_name, frag_p_name
    type(vk_pipeline_shader_stage_create_info), dimension(2) :: shader_stages
    ! VkDynamicState
    integer(c_int32_t), dimension(2), target :: dynamic_states
    type(vk_pipeline_dynamic_state_create_info) :: dynamic_state_create_info
    type(vk_pipeline_vertex_input_state_create_info) :: vertex_input_create_info
    type(vk_pipeline_input_assembly_state_create_info) :: input_assembly_create_info
    type(vk_viewport) :: viewport
    type(vk_rect_2d) :: scissor
    type(vk_pipeline_viewport_state_create_info) :: viewport_state_create_info
    type(vk_pipeline_rasterization_state_create_info) :: rasterization_state_create_info
    type(vk_pipeline_color_blend_attachment_state) :: color_blend_attachment
    type(vk_pipeline_layout_create_info), target :: pipeline_layout_create_info

    ! First compile GLSL into shader modules.
    vertex_shader_module = compile_glsl_shaders(logical_device, "vertex.vert")
    fragment_shader_module = compile_glsl_shaders(logical_device, "fragment.frag")

    ! Next, Create the vertex shader stage info.
    vertex_shader_stage_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%SHADER_STAGE_CREATE_INFO
    vertex_shader_stage_info%stage = VK_SHADER_STAGE_VERTEX_BIT
    vertex_shader_stage_info%module = vertex_shader_module
    vert_p_name = "main"//achar(0)
    vertex_shader_stage_info%p_name = c_loc(vert_p_name)

    ! Then, create the fragment shader stage create info.
    fragment_shader_stage_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%SHADER_STAGE_CREATE_INFO
    fragment_shader_stage_info%stage = VK_SHADER_STAGE_FRAGMENT_BIT
    fragment_shader_stage_info%module = fragment_shader_module
    frag_p_name = "main"//achar(0)
    fragment_shader_stage_info%p_name = c_loc(frag_p_name)

    ! Put them into an array.
    shader_stages = [vertex_shader_stage_info, fragment_shader_stage_info]

    ! Create vertex input create info.
    vertex_input_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%VERTEX_INPUT_STATE_CREATE_INFO
    vertex_input_create_info%vertex_binding_description_count = 0
    vertex_input_create_info%p_vertex_binding_descriptions = c_null_ptr
    vertex_input_create_info%vertex_attribute_description_count = 0
    vertex_input_create_info%p_vertex_attribute_descriptions = c_null_ptr

    ! Set up dynamic states for the pipeline.
    dynamic_states = [VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR]

    dynamic_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%DYNAMIC_STATE_CREATE_INFO
    dynamic_state_create_info%dynamic_state_count = size(dynamic_states)
    dynamic_state_create_info%p_dynamic_states = c_loc(dynamic_states)

    ! Set up the input assembly create info.
    input_assembly_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%INPUT_ASSEMBLY_STATE_CREATE_INFO
    input_assembly_create_info%topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
    input_assembly_create_info%primitive_restart_enabled = VK_FALSE

    ! Set up the viewport.
    viewport%x = 0.0
    viewport%y = 0.0
    viewport%width = swapchain_extent%width
    viewport%height = swapchain_extent%height
    viewport%min_depth = 0.0
    viewport%max_depth = 1.0

    ! Set up scissor.
    scissor%offset = vk_offset_2d()
    scissor%extent = swapchain_extent

    ! Set up viewport state create info.
    viewport_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%VIEWPORT_STATE_CREATE_INFO
    viewport_state_create_info%viewport_count = 1
    viewport_state_create_info%scissor_count = 1

    ! Set up rasterization state create info.
    rasterization_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%RASTERIZATION_STATE_CREATE_INFO
    rasterization_state_create_info%depth_clamp_enable = VK_FALSE
    rasterization_state_create_info%rasterizer_discard_enable = VK_FALSE
    rasterization_state_create_info%polygon_mode = VK_POLYGON_MODE_FILL
    rasterization_state_create_info%line_width = 1.0
    rasterization_state_create_info%cull_mode = VK_CULL_MODE_BACK_BIT
    !! FIXME: ENABLE COUNTERCLOCKWISE!
    rasterization_state_create_info%front_face = VK_FRONT_FACE_CLOCKWISE
    rasterization_state_create_info%depth_bias_enable = VK_FALSE
    rasterization_state_create_info%depth_bias_constant_factor = 0.0
    rasterization_state_create_info%depth_bias_clamp = 0.0
    rasterization_state_create_info%depth_bias_slope_factor = 0.0

    ! todo: maybe enable multi sampling in the options. :D

    ! Set up color blend attachment.
    color_blend_attachment%color_write_mask = ior(VK_COLOR_COMPONENT_R_BIT, ior(VK_COLOR_COMPONENT_G_BIT, ior(VK_COLOR_COMPONENT_B_BIT, VK_COLOR_COMPONENT_A_BIT)))
    color_blend_attachment%blend_enable = VK_FALSE
    color_blend_attachment%src_color_blend_factor = VK_BLEND_FACTOR_ONE
    color_blend_attachment%dst_color_blend_factor = VK_BLEND_FACTOR_ZERO
    color_blend_attachment%color_blend_op = VK_BLEND_OP_ADD
    color_blend_attachment%src_alpha_blend_factor = VK_BLEND_FACTOR_ONE
    color_blend_attachment%dst_alpha_blend_factor = VK_BLEND_FACTOR_ZERO
    color_blend_attachment%alpha_blend_op = VK_BLEND_OP_ADD


    ! Set up the pipeline layout create info.
    pipeline_layout_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%LAYOUT_CREATE_INFO
    pipeline_layout_create_info%set_layout_count = 0
    pipeline_layout_create_info%p_set_layouts = c_null_ptr
    pipeline_layout_create_info%push_constant_range_count = 0
    pipeline_layout_create_info%p_push_constant_ranges = c_null_ptr


    if (vk_create_pipeline_layout(logical_device, c_loc(pipeline_layout_create_info), c_null_ptr, pipeline_layout) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create pipeline layout."
    end if


    call vk_destroy_shader_module(logical_device, fragment_shader_module, c_null_ptr)
    call vk_destroy_shader_module(logical_device, vertex_shader_module, c_null_ptr)
  end subroutine create_graphics_pipeline


end module vulkan_driver_create_graphics_pipeline