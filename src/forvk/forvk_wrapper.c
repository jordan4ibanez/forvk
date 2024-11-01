#include <stdlib.h>
#include <assert.h>
#include <vulkan/vulkan_core.h>

VkInstance *forvk_grab_instance_pointer()
{
  void *data = malloc(sizeof(VkInstance));

  assert(data);

  return (VkInstance *)data;
}
