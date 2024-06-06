using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/* TODO: function to check inactivity
wall kick
create bound
if y = shadow y, landed
shadow do not exceed grid
spawn one by one
*/

public class Tetrominoes : MonoBehaviour
{
    public GameObject board;
    public GameObject shadow;

    public float fallTime = 1f;
    public float softDropTime;
    public float fallTimeCounter = 0f;
    public float landTimeCounter = 0f;

    public Vector3 rotationPoint;
    public Vector3 spawnLocation = new Vector3(4, 20, 0);
    public bool landed = false;
    public bool placed = false;
    public bool isCurrentPiece = false;
    public bool inHold = false;
    public bool isShadow = false;

    // Start is called before the first frame update
    void Start()
    {
        board = GameObject.Find("Board");
        softDropTime = fallTime/10;

        if (this.tag == "I") {
            rotationPoint = new Vector3(0.5f, -0.5f, 0);
        }

        if (this.tag == "J") {
            rotationPoint = new Vector3(0, 0, 0);
        }

        if (this.tag == "L") {
            rotationPoint = new Vector3(0, 0, 0);
        }

        if (this.tag == "O") {
            rotationPoint = new Vector3(0.5f, 0.5f, 0);
        }

        if (this.tag == "S") {
            rotationPoint = new Vector3(0.5f, 0.5f, 0);
        }

        if (this.tag == "T") {
            rotationPoint = new Vector3(0, 0, 0);
        }

        if (this.tag == "Z") {
            rotationPoint = new Vector3(0.5f, 0.5f, 0);
        }
    }

    // Update is called once per frame
    void Update()
    {

    }
}