# DMUX
Command demultiplexer for admins and academics

## Usage

 `dmux USER ADDRESSES (COMMAND | SCRIPTFILE) [OUTFILE]`

|            |                                |
| -          | -                              |
| USER       | ssh user name                  |
| ADDRESSES  | nmap compatible address string |
| COMMAND    | command to execute             |
| SCRIPTFILE | shell script file to execute   |
| OUTFILE    | optional output file           |
|            |                                |

## Examples
 
Write the `hostname` from hosts in the range `10.13.19.2-25` where the user name is `ubuntu` in `hosts.txt`.

```bash
dmux ubuntu 10.13.19.2-25 hostname hosts.txt
```

Output the `hostname` from hosts in the range `10.13.19.2-25` where the user name is `ubuntu`.

```bash
dmux ubuntu 10.13.19.2-25 hostname
```

## Notes

- Currently requires ssh keys to be pre-distributed ssh-copy-id is useful for this task.
- Currently does not validate argument contents, use them correctly or suffer completely unknown consequences.

## TODOs

- Confirm args are feasible
- Add traps so that ctrl+c is less dangerous
- Check that ssh id is trusted or prompt for password
- Verify dependencies exist
- Sentinel values for start and stop, random or hashed