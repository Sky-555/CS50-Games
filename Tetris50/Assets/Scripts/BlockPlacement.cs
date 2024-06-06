using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlockPlacement : MonoBehaviour
{
    // Start is called before the first frame update
    public AudioSource blockplacement;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }


    public void PlaySound() {
        blockplacement.Play();
    }
}
