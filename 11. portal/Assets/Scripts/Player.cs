using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Characters.FirstPerson;

public class Player : MonoBehaviour
{
    private Vector3 initialPos;
    private Quaternion initialParentRot;
    private Quaternion initialChildRot;

    // Start is called before the first frame update
    void Start()
    {
        // distinction between parent and child to make reseting complete, camera will not look directly parallel to ground without it.
        initialPos = transform.position;
        initialParentRot = transform.rotation;
        initialChildRot = transform.GetChild(0).transform.rotation;
    }

    // Update is called once per frame
    void Update()
    {
        // respawn at initial position
        if (transform.position.y < -2) {
            ResetPosition();
        }
    }

    public void ResetPosition() {
        float xRot = transform.rotation.x;
        float yRot = transform.rotation.y;
        float zRot = transform.rotation.z;

        // set the parent object's position and y rotation to face front
        transform.SetPositionAndRotation(initialPos, Quaternion.identity);
        transform.rotation = initialParentRot;

        // reset the x rotation of the FPS
        transform.GetChild(0).transform.rotation = initialChildRot;

        GetComponent<FirstPersonController>().MouseReset();
    }
}
