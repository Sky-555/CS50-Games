using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOver : MonoBehaviour
{
    // GameOver Scene

    void Start()
    {
        StartCoroutine(Restart());
    }

    IEnumerator Restart() {
        // pause 5 seconds, then back to Title Scene
		yield return new WaitForSeconds(3f);
        SceneManager.LoadScene("Title");
    }
}
