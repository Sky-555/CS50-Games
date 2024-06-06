using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Player : MonoBehaviour {
    // Keep traack of level and the y transform. If lower than 3 blocks will trigger Game Over Scene

    public GameObject player;
    public static int level = 1;

    void Update () {
        if (player.transform.position.y < -3) {
            SceneManager.LoadScene("GameOver");
            level = 1;
        }
    }
}