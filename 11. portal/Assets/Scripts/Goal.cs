using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Goal : MonoBehaviour
{
    public GameObject player;
    public GameObject WinText;
    private Text text;
    private static bool goaled;

    // Start is called before the first frame update
    void Start()
    {
        text = WinText.GetComponent<Text>();
        text.color = new Color(1, 1, 1, 0);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Submit") && goaled) {
            player.GetComponent<Player>().ResetPosition();
            goaled = false;
            text.color = new Color(1, 1, 1, 0);
        }
    }


    // done slightly different as I used mesh collider instead of box collider.
    void OnTriggerEnter(Collider other) {
        goaled = true;
        text.color = new Color(1, 1, 1, 1);
    }
}
