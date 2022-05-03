#include <metal_stdlib> 
using namespace metal;

/*
struct VertexIn {
  float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
  return vertex_in.position;
}

fragment float4 fragment_main() {
  return float4(1, 0, 0, 1);
}
*/

typedef struct {
  vector_float2 position;
  vector_float4 color;
} Vertex;

static const Vertex triangleVerteces[] = {
  //   2D pos        RGBA colors
  { { 250, -250 }, { 1, 0, 0, 1 } },
  { { -250, -250 }, { 0, 1, 0, 1 } },
  { { 0, 250 }, { 0, 0, 1, 1 } },
}

struct RasterizerData {
  float4 position [[position]];
  float4 color;
}
