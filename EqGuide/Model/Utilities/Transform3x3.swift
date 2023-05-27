//
//  Transform3x3.swift
//  Build transformation matricies for rotating points in column vectors.
//  Pre multiply transforms
//  To apply T1 then T2 to oldPoints, newPoints = T2 * T1 * oldPoints
//
//  Created by Barry Bryant on 5/27/23.
//

import simd

// constants for indexing 3D vectors
let X = 0
let Y = 1
let Z = 2

func zRot3x3(psiRad :Float) -> simd_float3x3 {
  var tform = matrix_identity_float3x3

  tform[0,0] = cosf(psiRad)
  tform[1,1] = cosf(psiRad)
  tform[0,1] = -sinf(psiRad)
  tform[1,0] = sinf(psiRad)
    
  return tform
}

func yRot3x3(phiRad: Float) -> simd_float3x3 {
  var tform = matrix_identity_float3x3

  tform[0,0] = cosf(phiRad)
  tform[2,2] = cosf(phiRad)
  tform[0,2] = sinf(phiRad)
  tform[2,0] = -sinf(phiRad)
    
  return tform
}

func xRot3x3(thetaRad: Float) -> simd_float3x3 {
  var tform = matrix_identity_float3x3

  tform[1,1] = cosf(thetaRad)
  tform[2,2] = cosf(thetaRad)
  tform[1,2] = -sinf(thetaRad)
  tform[2,1] = sinf(thetaRad)
    
  return tform
}
